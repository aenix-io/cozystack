package telemetry

import (
	"bytes"
	"context"
	"fmt"
	"net/http"
	"strings"
	"time"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/types"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/log"

	cozyv1alpha1 "github.com/aenix-io/cozystack/api/v1alpha1"
)

// Collector handles telemetry data collection and sending
type Collector struct {
	client client.Client
	config *Config
	ticker *time.Ticker
	stopCh chan struct{}
}

// NewCollector creates a new telemetry collector
func NewCollector(client client.Client, config *Config) *Collector {
	return &Collector{
		client: client,
		config: config,
	}
}

// Start implements manager.Runnable
func (c *Collector) Start(ctx context.Context) error {
	if c.config.Disabled {
		return nil
	}

	c.ticker = time.NewTicker(c.config.Interval)
	c.stopCh = make(chan struct{})

	// Initial collection
	c.collect(ctx)

	for {
		select {
		case <-ctx.Done():
			c.ticker.Stop()
			close(c.stopCh)
			return nil
		case <-c.ticker.C:
			c.collect(ctx)
		}
	}
}

// NeedLeaderElection implements manager.LeaderElectionRunnable
func (c *Collector) NeedLeaderElection() bool {
	// Only run telemetry collector on the leader
	return true
}

// Stop halts telemetry collection
func (c *Collector) Stop() {
	close(c.stopCh)
}

// collect gathers and sends telemetry data
func (c *Collector) collect(ctx context.Context) {
	logger := log.FromContext(ctx)

	// Get cluster ID from kube-system namespace
	var kubeSystemNS corev1.Namespace
	if err := c.client.Get(ctx, types.NamespacedName{Name: "kube-system"}, &kubeSystemNS); err != nil {
		logger.Error(err, "Failed to get kube-system namespace")
		return
	}

	clusterID := string(kubeSystemNS.UID)

	// Get Kubernetes version from nodes
	var nodeList corev1.NodeList
	if err := c.client.List(ctx, &nodeList); err != nil {
		logger.Error(err, "Failed to list nodes")
		return
	}

	// Create metrics buffer
	var metrics strings.Builder

	// Add CozyStack info metric
	if len(nodeList.Items) > 0 {
		k8sVersion := nodeList.Items[0].Status.NodeInfo.KubeletVersion
		metrics.WriteString(fmt.Sprintf(
			"cozystack_info{version=\"%s\",kubernetes_version=\"%s\"} 1\n",
			c.config.CozyStackVersion,
			k8sVersion,
		))
	}

	// Collect node metrics
	nodeOSCount := make(map[string]int)
	for _, node := range nodeList.Items {
		key := fmt.Sprintf("%s (%s)", node.Status.NodeInfo.OperatingSystem, node.Status.NodeInfo.OSImage)
		nodeOSCount[key] = nodeOSCount[key] + 1
	}

	for osKey, count := range nodeOSCount {
		metrics.WriteString(fmt.Sprintf(
			"nodes_count{os=\"%s\",kernel=\"%s\"} %d\n",
			osKey,
			nodeList.Items[0].Status.NodeInfo.KernelVersion,
			count,
		))
	}

	// Collect workload metrics
	var monitorList cozyv1alpha1.WorkloadMonitorList
	if err := c.client.List(ctx, &monitorList); err != nil {
		logger.Error(err, "Failed to list WorkloadMonitors")
		return
	}

	for _, monitor := range monitorList.Items {
		metrics.WriteString(fmt.Sprintf(
			"workload_count{uid=\"%s\",kind=\"%s\",type=\"%s\",version=\"%s\"} %d\n",
			clusterID,
			monitor.Spec.Kind,
			monitor.Spec.Type,
			monitor.Spec.Version,
			monitor.Status.ObservedReplicas,
		))
	}

	// Send metrics
	if err := c.sendMetrics(clusterID, metrics.String()); err != nil {
		logger.Error(err, "Failed to send metrics")
	}
}

// sendMetrics sends collected metrics to the configured endpoint
func (c *Collector) sendMetrics(clusterID, metrics string) error {
	req, err := http.NewRequest("POST", c.config.Endpoint, bytes.NewBufferString(metrics))
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "text/plain")
	req.Header.Set("X-Cluster-ID", clusterID)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("failed to send request: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	return nil
}

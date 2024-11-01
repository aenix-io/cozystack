package config

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v2"
)

// ResourceConfig represents the structure of the configuration file.
type ResourceConfig struct {
	Resources []Resource `yaml:"resources"`
}

// Resource describes an individual resource.
type Resource struct {
	Application ApplicationConfig `yaml:"application"`
	Release     ReleaseConfig     `yaml:"release"`
}

// ApplicationConfig contains the application settings.
type ApplicationConfig struct {
	Kind       string   `yaml:"kind"`
	Singular   string   `yaml:"singular"`
	Plural     string   `yaml:"plural"`
	ShortNames []string `yaml:"shortNames"`
}

// ReleaseConfig contains the release settings.
type ReleaseConfig struct {
	Prefix string            `yaml:"prefix"`
	Labels map[string]string `yaml:"labels"`
	Chart  ChartConfig       `yaml:"chart"`
}

// ChartConfig contains the chart settings.
type ChartConfig struct {
	Name      string          `yaml:"name"`
	SourceRef SourceRefConfig `yaml:"sourceRef"`
}

// SourceRefConfig contains the reference to the chart source.
type SourceRefConfig struct {
	Kind      string `yaml:"kind"`
	Name      string `yaml:"name"`
	Namespace string `yaml:"namespace"`
}

// LoadConfig loads the configuration from the specified path and validates it.
func LoadConfig(path string) (*ResourceConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	var config ResourceConfig
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, err
	}

	// Validate the configuration.
	for i, res := range config.Resources {
		if res.Application.Kind == "" {
			return nil, fmt.Errorf("resource at index %d has an empty kind", i)
		}
		if res.Application.Plural == "" {
			return nil, fmt.Errorf("resource at index %d has an empty plural", i)
		}
		if res.Release.Prefix == "" {
			return nil, fmt.Errorf("resource at index %d has an empty release prefix", i)
		}
		if res.Release.Chart.Name == "" {
			return nil, fmt.Errorf("resource at index %d has an empty chart name in release", i)
		}
		if res.Release.Chart.SourceRef.Kind == "" || res.Release.Chart.SourceRef.Name == "" || res.Release.Chart.SourceRef.Namespace == "" {
			return nil, fmt.Errorf("resource at index %d has an incomplete sourceRef for chart in release", i)
		}
	}
	return &config, nil
}

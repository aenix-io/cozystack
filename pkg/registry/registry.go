package registry

import (
	"github.com/aenix.io/cozystack/pkg/registry/apps/application"
	"k8s.io/apimachinery/pkg/runtime/schema"
	genericregistry "k8s.io/apiserver/pkg/registry/generic/registry"
	"k8s.io/apiserver/pkg/registry/rest"
)

// REST implements a RESTStorage for API services against etcd
type REST struct {
	*genericregistry.Store
	GVK schema.GroupVersionKind
}

// Implement the GroupVersionKindProvider interface
func (r *REST) GroupVersionKind(containingGV schema.GroupVersion) schema.GroupVersionKind {
	return r.GVK
}

// RESTInPeace creates REST for Application
func RESTInPeace(r *application.REST) rest.Storage {
	return r
}

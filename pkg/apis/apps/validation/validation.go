/*
Copyright 2024 The Cozystack Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package validation

import (
	"github.com/aenix-io/cozystack/pkg/apis/apps"
	"k8s.io/apimachinery/pkg/util/validation/field"
)

// ValidateApplication validates a Application.
func ValidateApplication(f *apps.Application) field.ErrorList {
	allErrs := field.ErrorList{}

	allErrs = append(allErrs, ValidateApplicationSpec(&f.Spec, field.NewPath("spec"))...)

	return allErrs
}

// ValidateApplicationSpec validates a ApplicationSpec.
func ValidateApplicationSpec(s *apps.ApplicationSpec, fldPath *field.Path) field.ErrorList {
	allErrs := field.ErrorList{}

	// TODO validation

	return allErrs
}

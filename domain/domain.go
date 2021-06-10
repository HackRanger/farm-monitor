package domain

import (
	"github.com/google/uuid"
)

const (
	SMS   = 0
	EMAIL = 1
	NOISE = 2
)

type ImageTag struct {
	Tag        string  `json:"Tag"`
	Confidance float64 `json:"Confidance"`
}

// Alert define method
type Alert struct {
	Name      string
	ID        uuid.UUID
	AlertType int
	Enable    bool
}

// AlertRepository  method supported on alerts
type AlertRepository interface {
	AddAlert(alert Alert) error
	RemoveAlert(alert Alert) error
	UpdateAlert(alert Alert) error
}

// Other Utility Methods goes here

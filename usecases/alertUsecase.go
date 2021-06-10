package usecases

import (
	"github.com/google/uuid"
	"github.com/hackranger/farm-monitor/domain"
)

// AlertRepository  method supported on alerts
type AlertRepository interface {
	AddAlert(alert domain.Alert) error
	RemoveAlert(alert domain.Alert) error
	UpdateAlert(alert domain.Alert) error
}

// Alert define method
type Alert struct {
	Name      string
	AlertType int
	Enable    bool
}

type OrderInteractor struct {
	AlertRepository domain.AlertRepository
}

func (interactor *OrderInteractor) AddAlert(name string, alertType int, enabled bool) error {
	uid := uuid.New()
	a := domain.Alert{
		Name:      name,
		AlertType: alertType,
		ID:        uid,
		Enable:    enabled,
	}

	interactor.AlertRepository.AddAlert(a)
	return nil
}

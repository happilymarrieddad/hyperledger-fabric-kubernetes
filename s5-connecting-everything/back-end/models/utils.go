package models

import (
	"github.com/google/uuid"
)

func genUUID() (ID string, err error) {
	id, err := uuid.NewUUID()
	if err != nil {
		return
	}

	ID = id.String()
	return
}

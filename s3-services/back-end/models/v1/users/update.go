package users

import (
	"errors"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
)

func Update(id string, usr *models.User) (*models.User, error) {
	var exists bool

	for index, user := range mockUsers {
		if user.ID == id {
			mockUsers[index] = *usr
			exists = true
		}
	}

	if !exists {
		return nil, errors.New("unable to update user because user was not found")
	}

	return usr, nil
}

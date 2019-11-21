package users

import (
	"errors"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
)

type UpdateOpts struct {
	Replace bool
}

func Update(id string, usr *models.User, opts *UpdateOpts) (*models.User, error) {
	var exists bool

	if opts == nil {
		opts = &UpdateOpts{}
	}

	for index, user := range mockUsers {
		if user.ID == id {

			if opts.Replace {
				usr.ID = mockUsers[index].ID
				usr.Password = mockUsers[index].Password
				usr.Email = mockUsers[index].Email
				mockUsers[index] = *usr
			} else {
				if len(usr.FirstName) > 0 {
					mockUsers[index].FirstName = usr.FirstName
				}
				if len(usr.LastName) > 0 {
					mockUsers[index].LastName = usr.LastName
				}
			}
			exists = true
			usr = &mockUsers[index]
		}
	}

	if !exists {
		return nil, errors.New("unable to update user because user was not found")
	}

	return usr, nil
}

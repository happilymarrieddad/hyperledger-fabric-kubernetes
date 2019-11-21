package rawresourcetypes

import (
	"errors"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"
)

type UpdateOpts struct {
	Replace bool
}

func Update(id string, usr *models.RawResourceType, opts *UpdateOpts) (*models.RawResourceType, error) {
	var exists bool

	if opts == nil {
		opts = &UpdateOpts{}
	}

	for index, rawresourcetype := range mockRawResourceTypes {
		if rawresourcetype.ID == id {

			if opts.Replace {
				usr.ID = mockRawResourceTypes[index].ID
				mockRawResourceTypes[index] = *usr
			} else {
				if len(usr.Name) > 0 {
					mockRawResourceTypes[index].Name = usr.Name
				}
			}
			exists = true
			usr = &mockRawResourceTypes[index]
		}
	}

	if !exists {
		return nil, errors.New("unable to update rawresourcetype because rawresourcetype was not found")
	}

	return usr, nil
}

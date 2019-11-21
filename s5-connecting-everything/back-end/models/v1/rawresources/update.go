package rawresources

import (
	"errors"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
)

type UpdateOpts struct {
	Replace bool
}

func Update(id string, usr *models.RawResource, opts *UpdateOpts) (*models.RawResource, error) {
	var exists bool

	if opts == nil {
		opts = &UpdateOpts{}
	}

	for index, rawresource := range mockRawResources {
		if rawresource.ID == id {

			if opts.Replace {
				usr.ID = mockRawResources[index].ID
				usr.ArrivalTime = mockRawResources[index].ArrivalTime
				usr.Timestamp = mockRawResources[index].Timestamp
				mockRawResources[index] = *usr
			} else {
				if len(usr.Name) > 0 {
					mockRawResources[index].Name = usr.Name
				}
				if len(usr.TypeID) > 0 {
					mockRawResources[index].TypeID = usr.TypeID
				}
				if usr.Weight > 0 {
					mockRawResources[index].Weight = usr.Weight
				}
			}
			exists = true
			usr = &mockRawResources[index]
		}
	}

	if !exists {
		return nil, errors.New("unable to update rawresource because rawresource was not found")
	}

	return usr, nil
}

package rawresources

import (
	"errors"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
)

func Show(id string) (*models.RawResource, error) {

	for index, rawresource := range mockRawResources {
		if rawresource.ID == id {
			return &mockRawResources[index], nil
		}
	}

	return nil, errors.New("unable to find rawresource")
}

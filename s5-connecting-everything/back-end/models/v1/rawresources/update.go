package rawresources

import (
	"encoding/json"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/hyperledger"
)

type UpdateOpts struct {
	Replace bool
}

func Update(clients *hyperledger.Clients,id string, rr *models.RawResource, opts *UpdateOpts) (*models.RawResource, error) {
	if !opts.Replace {
		existingRawResource, err := Show(clients, id)
		if err != nil {
			return nil, err
		}

		if rr.Name != "" && existingRawResource.Name != rr.Name {
			existingRawResource.Name = rr.Name
		}

		if rr.TypeID != "" && existingRawResource.TypeID != rr.TypeID {
			existingRawResource.TypeID = rr.TypeID
		}

		if rr.Weight > 0 && existingRawResource.Weight != rr.Weight {
			existingRawResource.Weight = rr.Weight
		}
	}

	packet, err := json.Marshal(rr)
	if err != nil {
		return nil, err
	}

	if _, err = clients.Invoke("org1", "rawresources", "update", [][]byte{
		[]byte(id),
		packet,
	}); err != nil {
		return nil, err
	}

	return rr, nil
}

package rawresources

import (
	"errors"
	"encoding/json"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/hyperledger"
)

type UpdateOpts struct {
	Replace bool
}

func Update(clients *hyperledger.Clients,id string, usr *models.RawResource, opts *UpdateOpts) (*models.RawResource, error) {
	if opts.Replace {
		packet, err := json.Marshal(usr)
		if err != nil {
			return nil, err
		}

		if _, err = clients.Invoke("org1", "rawresources", "update", [][]byte{
			[]byte(id),
			packet,
		}); err != nil {
			return nil, err
		}
	} else {
		return nil, errors.New("patch is not implemented yet")
	}

	return usr, nil
}

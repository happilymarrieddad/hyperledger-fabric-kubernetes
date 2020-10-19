package rawresources

import (
	"encoding/json"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/hyperledger"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"
)

func Index(clients *hyperledger.Clients) (rawresources *models.RawResources, err error) {
	rawresources = new(models.RawResources)

	res, err := clients.Query("org1", "mainchannel", "rawresources", "queryString", [][]byte{
		[]byte("{\"selector\":{ \"visible\": { \"$eq\":true } }}"),
	})
	if err != nil {
		return
	}

	if err = json.Unmarshal(res, rawresources); err != nil {
		return
	}

	return
}

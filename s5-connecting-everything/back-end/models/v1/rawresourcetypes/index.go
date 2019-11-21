package rawresourcetypes

import "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"

func Index() (rawresourcetypes *models.RawResourceTypes, err error) {
	rawresourcetypes = &mockRawResourceTypes

	return
}

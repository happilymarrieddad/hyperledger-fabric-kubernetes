package rawresourcetypes

import "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"

func Index() (rawresourcetypes *models.RawResourceTypes, err error) {
	rawresourcetypes = &mockRawResourceTypes

	return
}

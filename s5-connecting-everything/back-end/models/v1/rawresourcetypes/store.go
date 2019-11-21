package rawresourcetypes

import "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"

func Store(name string) (rawresourcetype *models.RawResourceType, err error) {
	rawresourcetype, err = models.NewRawResourceType(name)
	if err != nil {
		return
	}

	mockRawResourceTypes = append(mockRawResourceTypes, *rawresourcetype)

	return
}

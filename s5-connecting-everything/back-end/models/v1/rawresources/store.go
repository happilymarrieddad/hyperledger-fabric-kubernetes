package rawresources

import (
	"time"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
)

func Store(name string, typeID string, weight int, arrivalTime *time.Time) (rawresource *models.RawResource, err error) {
	rawresource, err = models.NewRawResource(name, typeID, weight, arrivalTime)
	if err != nil {
		return
	}

	mockRawResources = append(mockRawResources, *rawresource)

	return
}

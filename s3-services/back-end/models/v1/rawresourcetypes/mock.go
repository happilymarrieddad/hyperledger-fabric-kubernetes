package rawresourcetypes

import (
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
)

var mockRawResourceTypes models.RawResourceTypes

func init() {
	iron, _ := models.NewRawResourceType("Iron")
	copper, _ := models.NewRawResourceType("Copper")
	platinum, _ := models.NewRawResourceType("Platinum")

	mockRawResourceTypes = models.RawResourceTypes{
		*iron,
		*copper,
		*platinum,
	}
}

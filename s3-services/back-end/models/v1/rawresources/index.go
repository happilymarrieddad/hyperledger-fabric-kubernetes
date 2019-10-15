package rawresources

import "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"

func Index() (rawresources *models.RawResources, err error) {
	rawresources = &mockRawResources

	return
}

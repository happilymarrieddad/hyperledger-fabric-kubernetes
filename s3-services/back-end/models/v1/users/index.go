package users

import "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"

func Index() (users *models.Users, err error) {
	users = &mockUsers

	return
}

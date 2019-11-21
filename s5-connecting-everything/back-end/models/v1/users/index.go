package users

import "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"

func Index() (users *models.Users, err error) {
	users = &mockUsers

	return
}

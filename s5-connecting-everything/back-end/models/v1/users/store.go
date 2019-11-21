package users

import "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"

func Store(firstName string, lastName string, email string, password string) (user *models.User, err error) {
	user, err = models.NewUser(firstName, lastName, email, password)
	if err != nil {
		return
	}

	mockUsers = append(mockUsers, *user)

	return
}

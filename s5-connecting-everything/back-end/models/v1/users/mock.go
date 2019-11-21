package users

import (
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"
)

var mockUsers models.Users

func init() {
	usr, _ := models.NewUser("Nick", "Kotenberg", "nick@mail.com", "1234")

	mockUsers = models.Users{
		*usr,
	}
}

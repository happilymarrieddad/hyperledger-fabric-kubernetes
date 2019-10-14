package users

import (
	"errors"
)

func Destroy(id string) error {
	var exists bool

	for index, user := range mockUsers {
		if user.ID == id {
			mockUsers = append(mockUsers[:index], mockUsers[index+1:]...)
			exists = true
		}
	}

	if !exists {
		return errors.New("unable to delete user because user was not found")
	}

	return nil
}

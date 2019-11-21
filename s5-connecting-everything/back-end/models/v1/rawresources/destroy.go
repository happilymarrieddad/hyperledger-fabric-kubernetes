package rawresources

import (
	"errors"
)

func Destroy(id string) error {
	var exists bool

	for index, rawresource := range mockRawResources {
		if rawresource.ID == id {
			mockRawResources = append(mockRawResources[:index], mockRawResources[index+1:]...)
			exists = true
		}
	}

	if !exists {
		return errors.New("unable to delete rawresource because rawresource was not found")
	}

	return nil
}

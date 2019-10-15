package rawresourcetypes

import (
	"errors"
)

func Destroy(id string) error {
	var exists bool

	for index, rawresourcetype := range mockRawResourceTypes {
		if rawresourcetype.ID == id {
			mockRawResourceTypes = append(mockRawResourceTypes[:index], mockRawResourceTypes[index+1:]...)
			exists = true
		}
	}

	if !exists {
		return errors.New("unable to delete rawresourcetype because rawresourcetype was not found")
	}

	return nil
}

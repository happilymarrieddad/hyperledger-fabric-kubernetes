package models

import "time"

type RawResourceTypes []RawResourceType

type RawResourceType struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

func NewRawResourceType(name string) (rawResourceType *RawResourceType, err error) {
	rawResourceType = new(RawResourceType)

	if rawResourceType.ID, err = genUUID(); err != nil {
		return
	}

	rawResourceType.Name = name

	return
}

type RawResources []RawResource

type RawResource struct {
	ID          string     `json:"id"`
	Name        string     `json:"name"`
	TypeID      string     `json:"type_id"`
	Weight      int        `json:"weight"`
	ArrivalTime *time.Time `json:"arrival_time"`
	Timestamp   *time.Time `json:"timestamp"`
}

func NewRawResource(name string, typeId string, weight int, arrivalTime *time.Time) (rawResource *RawResource, err error) {
	rawResource = new(RawResource)

	if rawResource.ID, err = genUUID(); err != nil {
		return
	}

	rawResource.Name = name
	rawResource.TypeID = typeId
	rawResource.Weight = weight

	t := time.Now()
	if arrivalTime == nil {
		rawResource.ArrivalTime = arrivalTime
	} else {
		rawResource.ArrivalTime = &t
	}

	rawResource.Timestamp = &t

	return
}

package main

// https://hyperledger-fabric.readthedocs.io/en/latest/chaincode4ade.html
import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	cc, err := contractapi.NewChaincode(&ResourcesContract{})

	if err != nil {
		panic(err.Error())
	}

	if err := cc.Start(); err != nil {
		panic(err.Error())
	}
}

// ResourcesContract contract for handling writing and reading from the world state
type ResourcesContract struct {
	contractapi.Contract
}

// Resource resource
type Resource struct {
	ID             string `json:"id"`
	Name           string `json:"name"`
	ResourceTypeID string `json:"resource_type_id"`
}

// InitLedger adds a base set of cars to the ledger
func (rc *ResourcesContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
}

// Create adds a new id with value to the world state
func (rc *ResourcesContract) Create(ctx contractapi.TransactionContextInterface, id string, name string, resourceTypeID string) error {
	existing, err := ctx.GetStub().GetState(id)

	if err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	if existing != nil {
		return fmt.Errorf("Cannot create world state pair with id %s. Already exists", id)
	}

	newResource := &Resource{
		ID:             id,
		Name:           name,           // TODO: Verify this name is unique
		ResourceTypeID: resourceTypeID, // TODO: Verify that this is a valid resource_type_id
	}

	bytes, err := json.Marshal(newResource)
	if err != nil {
		return fmt.Errorf("Unable to marshal object")
	}

	if err = ctx.GetStub().PutState(id, bytes); err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	return nil
}

// Update changes the value with id in the world state
func (rc *ResourcesContract) Update(ctx contractapi.TransactionContextInterface, id string, value string) error {
	existing, err := ctx.GetStub().GetState(id)

	if err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	if existing == nil {
		return fmt.Errorf("Cannot update world state pair with id %s. Does not exist", id)
	}

	var existingResource *Resource
	if err = json.Unmarshal(existing, &existingResource); err != nil {
		return fmt.Errorf("Unable to unmarshal existing into object")
	}
	var suggestedResource *Resource
	if err = json.Unmarshal([]byte(value), &suggestedResource); err != nil {
		return fmt.Errorf("Unable to unmarshal existing into object")
	}

	if len(suggestedResource.Name) > 0 {
		existingResource.Name = suggestedResource.Name
	}

	if len(suggestedResource.ResourceTypeID) > 0 {
		existingResource.ResourceTypeID = suggestedResource.ResourceTypeID
	}

	newValue, err := json.Marshal(existingResource)
	if err != nil {
		return fmt.Errorf("Unable to marshal new object")
	}

	if err = ctx.GetStub().PutState(id, newValue); err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	return nil
}

// Read returns the value at id in the world state
func (rc *ResourcesContract) Read(ctx contractapi.TransactionContextInterface, id string) (ret *Resource, err error) {
	resultsIterator, _, err := ctx.GetStub().GetQueryResultWithPagination(`{"selector": {"id":"`+id+`"}}`, 0, "")
	if err != nil {
		return
	}
	defer resultsIterator.Close()

	if resultsIterator.HasNext() {
		ret = new(Resource)
		queryResponse, err2 := resultsIterator.Next()
		if err2 != nil {
			return nil, err2
		}

		if err = json.Unmarshal(queryResponse.Value, ret); err != nil {
			return
		}
	} else {
		return nil, fmt.Errorf("Unable to find item in world state")
	}

	return
}

// Index - read all resources from the world state
func (rc *ResourcesContract) Index(
	ctx contractapi.TransactionContextInterface,
) (rets []*Resource, err error) {
	resultsIterator, _, err := ctx.GetStub().GetQueryResultWithPagination(`{"selector": {"id":{"$ne":"-"}}}`, 0, "")
	if err != nil {
		return
	}
	defer resultsIterator.Close()

	for resultsIterator.HasNext() {
		queryResponse, err2 := resultsIterator.Next()
		if err2 != nil {
			return nil, err2
		}

		res := new(Resource)
		if err = json.Unmarshal(queryResponse.Value, res); err != nil {
			return
		}

		rets = append(rets, res)
	}

	return
}

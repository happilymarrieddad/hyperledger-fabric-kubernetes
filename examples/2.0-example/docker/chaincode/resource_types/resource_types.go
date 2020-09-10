package main

// https://hyperledger-fabric.readthedocs.io/en/latest/chaincode4ade.html
import (
	"encoding/json"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	cc, err := contractapi.NewChaincode(&ResourceTypesContract{})

	if err != nil {
		panic(err.Error())
	}

	if err := cc.Start(); err != nil {
		panic(err.Error())
	}
}

// ResourceTypesContract contract for handling writing and reading from the world state
type ResourceTypesContract struct {
	contractapi.Contract
}

// ResourceType resource
type ResourceType struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// InitLedger adds a base set of cars to the ledger
func (rc *ResourceTypesContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	return nil
}

// Create adds a new id with value to the world state
func (rc *ResourceTypesContract) Create(ctx contractapi.TransactionContextInterface, id string, name string) error {
	existing, err := ctx.GetStub().GetState(id)

	if err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	if existing != nil {
		return fmt.Errorf("Cannot create world state pair with id %s. Already exists", id)
	}

	newResourceType := &ResourceType{
		ID:   id,
		Name: name, // TODO: Verify this name is unique
	}

	bytes, err := json.Marshal(newResourceType)
	if err != nil {
		return fmt.Errorf("Unable to marshal object")
	}

	if err = ctx.GetStub().PutState(id, bytes); err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	return nil
}

// Update changes the value with id in the world state
func (rc *ResourceTypesContract) Update(ctx contractapi.TransactionContextInterface, id string, value string) error {
	existing, err := ctx.GetStub().GetState(id)

	if err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	if existing == nil {
		return fmt.Errorf("Cannot update world state pair with id %s. Does not exist", id)
	}

	var existingResourceType *ResourceType
	if err = json.Unmarshal(existing, &existingResourceType); err != nil {
		return fmt.Errorf("Unable to unmarshal existing into object")
	}
	var suggestedResourceType *ResourceType
	if err = json.Unmarshal([]byte(value), &suggestedResourceType); err != nil {
		return fmt.Errorf("Unable to unmarshal existing into object")
	}

	if len(suggestedResourceType.Name) > 0 {
		existingResourceType.Name = suggestedResourceType.Name
	}

	newValue, err := json.Marshal(existingResourceType)
	if err != nil {
		return fmt.Errorf("Unable to marshal new object")
	}

	if err = ctx.GetStub().PutState(id, newValue); err != nil {
		return fmt.Errorf("Unable to interact with world state")
	}

	return nil
}

// Read returns the value at id in the world state
func (rc *ResourceTypesContract) Read(ctx contractapi.TransactionContextInterface, id string) (ret *ResourceType, err error) {
	resultsIterator, _, err := ctx.GetStub().GetQueryResultWithPagination(`{"selector": {"id":"`+id+`"}}`, 0, "")
	if err != nil {
		return
	}
	defer resultsIterator.Close()

	if resultsIterator.HasNext() {
		ret = new(ResourceType)
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
func (rc *ResourceTypesContract) Index(
	ctx contractapi.TransactionContextInterface,
) (rets []*ResourceType, err error) {
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

		res := new(ResourceType)
		if err = json.Unmarshal(queryResponse.Value, res); err != nil {
			return
		}

		rets = append(rets, res)
	}

	return
}

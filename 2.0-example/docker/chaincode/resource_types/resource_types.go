package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/google/uuid"
	"github.com/hyperledger/fabric-chaincode-go/shim"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {
	resourceTypesContract := new(ResourceTypesContract)

	cc, err := contractapi.NewChaincode(resourceTypesContract)

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

// ResourceType resource type
type ResourceType struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// InitLedger adds a base set of resource types to the ledger
func (rtc *ResourceTypesContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	types := []ResourceType{
		{
			ID:   uuid.New().String(),
			Name: "Raw Goods",
		},
		{
			ID:   uuid.New().String(),
			Name: "Processed Goods",
		},
	}

	for _, t := range types {
		typeAsBytes, err := json.Marshal(t)
		if err != nil {
			return errors.New("Unable to init ledger because type conversion failed")
		}

		if err := ctx.GetStub().PutState(t.ID, typeAsBytes); err != nil {
			return fmt.Errorf("Failed to put to world state. %s", err.Error())
		}
	}

	return nil
}

// Create adds a new key with value to the world state
func (rtc *ResourceTypesContract) Create(ctx contractapi.TransactionContextInterface, value string) error {
	var newResourceType ResourceType

	if err := json.Unmarshal([]byte(value), &newResourceType); err != nil {
		return err
	}

	newResourceType.ID = uuid.New().String()

	existing, err := ctx.GetStub().GetState(newResourceType.ID)

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	if existing != nil {
		return fmt.Errorf("Cannot create world state pair with key %s. Already exists", newResourceType.ID)
	}

	bytes, err := json.Marshal(newResourceType)
	if err != nil {
		return errors.New("Unable to marshal data")
	}

	if err = ctx.GetStub().PutState(newResourceType.ID, bytes); err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

// Update changes the value with key in the world state
func (rtc *ResourceTypesContract) Update(ctx contractapi.TransactionContextInterface, key string, value string) error {
	existing, err := ctx.GetStub().GetState(key)

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	if existing == nil {
		return fmt.Errorf("Cannot update world state pair with key %s. Does not exist", key)
	}

	err = ctx.GetStub().PutState(key, []byte(value))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

// Read returns the value at key in the world state
func (rtc *ResourceTypesContract) Read(ctx contractapi.TransactionContextInterface, key string) (string, error) {
	existing, err := ctx.GetStub().GetState(key)

	if err != nil {
		return "", errors.New("Unable to interact with world state")
	}

	if existing == nil {
		return "", fmt.Errorf("Cannot read world state pair with key %s. Does not exist", key)
	}

	return string(existing), nil
}

// Read all resource types from the world state
func (rtc *ResourceTypesContract) Index(
	ctx contractapi.TransactionContextInterface,
	query string,
	pageSize int32,
	bookmark string,
) (ret string, err error) {
	if len(query) == 0 {
		query = `{"selector": {"id":{"$ne":"-"}}}`
	}

	resultsIterator, _, err := ctx.GetStub().GetQueryResultWithPagination(query, pageSize, bookmark)
	if err != nil {
		return
	}
	defer resultsIterator.Close()

	buffer, err := constructQueryResponseFromIterator(resultsIterator)
	if err != nil {
		return
	}

	return buffer.String(), nil
}

// ===========================================================================================
// constructQueryResponseFromIterator constructs a JSON array containing query results from
// a given result iterator
// ===========================================================================================
func constructQueryResponseFromIterator(resultsIterator shim.StateQueryIteratorInterface) (*bytes.Buffer, error) {
	// buffer is a JSON array containing QueryResults
	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}
		// Add a comma before array members, suppress it for the first array member
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"Key\":")
		buffer.WriteString("\"")
		buffer.WriteString(queryResponse.Key)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Record\":")
		// Record is a JSON object, so we write as-is
		buffer.WriteString(string(queryResponse.Value))
		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return &buffer, nil
}

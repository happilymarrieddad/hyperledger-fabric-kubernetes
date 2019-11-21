package rawresourcetypes

import (
	"encoding/json"
	"net/http"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"

	RawResourceTypesModel "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models/v1/rawresourcetypes"
)

func Store() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		var rawresourcetype models.RawResourceType
		decoder := json.NewDecoder(r.Body)
		defer r.Body.Close()
		err := decoder.Decode(&rawresourcetype)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		newRawResourceType, err := RawResourceTypesModel.Store(
			rawresourcetype.Name,
		)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		packet, err := json.Marshal(newRawResourceType)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Write(packet)
	}
}

package rawresourcetypes

import (
	"encoding/json"
	"net/http"

	RawResourceTypesModel "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models/v1/rawresourcetypes"
)

func Index() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		rawresourcetypes, err := RawResourceTypesModel.Index()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}

		packet, err := json.Marshal(rawresourcetypes)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}

		w.Write(packet)
	}
}

package rawresources

import (
	"encoding/json"
	"net/http"

	RawResourcesModel "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models/v1/rawresources"
)

func Index() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		rawresources, err := RawResourcesModel.Index()
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}

		packet, err := json.Marshal(rawresources)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
		}

		w.Write(packet)
	}
}

package rawresources

import (
	"encoding/json"
	"net/http"

	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models"

	RawResourcesModel "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s3-services/backend/models/v1/rawresources"
)

func Store() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		var rawresource models.RawResource
		decoder := json.NewDecoder(r.Body)
		defer r.Body.Close()
		err := decoder.Decode(&rawresource)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		newRawResource, err := RawResourcesModel.Store(
			rawresource.Name,
			rawresource.TypeID,
			rawresource.Weight,
			rawresource.ArrivalTime,
		)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		packet, err := json.Marshal(newRawResource)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Write(packet)
	}
}

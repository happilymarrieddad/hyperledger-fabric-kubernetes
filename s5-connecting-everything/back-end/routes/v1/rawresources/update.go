package rawresources

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models"

	RawResourcesModel "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models/v1/rawresources"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/hyperledger"
)

func Update(clients *hyperledger.Clients) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		vars := mux.Vars(r)
		id := vars["id"]

		var opts RawResourcesModel.UpdateOpts
		var rawresource models.RawResource
		decoder := json.NewDecoder(r.Body)
		defer r.Body.Close()
		if err := decoder.Decode(&rawresource); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}

		if r.Method == "PUT" {
			opts.Replace = true
		}

		updatedRawResource, err := RawResourcesModel.Update(clients, id, &rawresource, &opts)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		packet, err := json.Marshal(updatedRawResource)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Write(packet)
	}
}

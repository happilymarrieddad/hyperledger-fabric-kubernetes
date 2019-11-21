package rawresources

import (
	"encoding/json"
	"net/http"

	RawResourcesModel "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models/v1/rawresources"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/hyperledger"
)

func Index(clients *hyperledger.Clients) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		rawresources, err := RawResourcesModel.Index(clients)
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

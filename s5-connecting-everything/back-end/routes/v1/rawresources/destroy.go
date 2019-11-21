package rawresources

import (
	"net/http"

	"github.com/gorilla/mux"

	RawResourcesModel "github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/models/v1/rawresources"
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/hyperledger"
)

func Destroy(clients *hyperledger.Clients) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		vars := mux.Vars(r)
		id := vars["id"]

		if err := RawResourcesModel.Destroy(clients, id); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Write([]byte("Success"))
	}
}

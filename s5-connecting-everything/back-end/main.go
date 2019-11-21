package main

import (
	"github.com/happilymarrieddad/hyperledger-fabric-kubernetes/s5-connecting-everything/backend/server"
)

func main() {
	s := server.NewServer()

	if err := s.Init(3000); err != nil {
		panic(err)
	}

	s.Start()
}

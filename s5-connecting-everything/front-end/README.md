# front-end

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Run your tests
```
npm run test
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).

docker network create --subnet 172.18.0.0/16 --gateway 172.18.0.1 -o com.docker.network.bridge.enable_icc=false -o com.docker.network.bridge.name=default.svc.cluster.local default.svc.cluster.local
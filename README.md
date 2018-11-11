### Bitcoind Node 

Run bitcoind as docker container

### Getting Started
#### Compose

- `docker-compose build`
- `docker-compose up`

To run as daemon in background use `docker-compose up -d`

#### Docker run

- `docker build -t node_bitcoind .`
- `docker run -p 8332:8332 -p 8333:8333 node_bitcoind <commands>`

Where commands are bitcoind commands e.g. -server=1 


### Generate RPC username/password

- `cd rpcauth`
- `python3 rpcauth.py <username> <password>
- Copy output to `bitcoin.conf` or add as command to `docker-compose.yml`

### Thanks

These dockerfiles are based on the dockerfiles from https://github.com/ruimarinho/docker-bitcoin-core adding
 
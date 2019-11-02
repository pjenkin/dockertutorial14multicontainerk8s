# 15-259 Unique Deployment images - deploy shell script launched from .travis.yml
docker build -t peternjenkin/multi-client:latest -t peternjenkin/multi-client:$SHA -f ./client/Dockerfile ./client # build context of ./client folder
docker build -t peternjenkin/multi-server:latest -t peternjenkin/multi-server:$SHA -f ./server/Dockerfile ./server
docker build -t peternjenkin/multi-worker:latest -t peternjenkin/multi-worker:$SHA -f ./worker/Dockerfile ./worker # hand-typed! not copy/paste
# explicitly -t tag with 'latest', and also tag with the git SHA (from Travis CI environment variable - cf .travis.yml)
# 15-261 'Updating the deployment script'

# already logged-in to docker hub by .travis.yml by the time this shell script is called by .travis.yml

docker push peternjenkin/multi-client:latest
docker push peternjenkin/multi-server:latest
docker push peternjenkin/multi-worker:latest # push built images (step 7 build images (also for specifically tagged by 'latest') and push to docker hub)

docker push peternjenkin/multi-client:$SHA
docker push peternjenkin/multi-server:$SHA
docker push peternjenkin/multi-worker:$SHA # push built images (step 7 build images (also for specifically tagged by SHA for Travis CI environment variable) and push to docker hub)


kubectl apply -f k8s # step 8 - Apply all configs in the k8s folder

kubectl set image deployments/server-deployment server=peternjenkin/multi-server:$SHA # step 9 imperatively set *latest* images on each deployment (using git SHA - cf .travis.yml env)
kubectl set image deployments/client-deployment client=peternjenkin/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=peternjenkin/multi-worker:$SHA
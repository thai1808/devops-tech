LEVEL 1: triển khai deployment chạy nginx (default) lên kubernetes và cho phép truy cập từ bên ngoài thông qua nodePort

output:

1 deployment nginx (replicas=2 pod)
1 nodePort service trỏ tới deployment
thực hiên curl tới nodePort và cho ra kết quả trang web mặc định của nginx

Bước 1: Tạo deployment với image nginx và replicas=2
```
kubectl create deployment nginx --image nginx:latest --replicas=2 --dry-run=client -o yaml > nginx-deployment.yaml
```
Nội dung file nginx-deployment.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:latest
        name: nginx
        resources: {}
status: {}
```
Bước 2: Tạo NodePort Service
```
kubectl create service nodeport nginx --tcp=80:80 --dry-run=client -o yaml > nginx-service.yaml
```
Nội dung file nginx-service.yaml:
```
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
spec:
  ports:
  - name: 80-80
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: NodePort
status:
  loadBalancer: {}
```

Kiểm tra trạng thái của service: https://prnt.sc/7VnWwsbg3V5N

Truy cập vào ứng dụng: https://prnt.sc/Qb0glSbTk6SF , https://prnt.sc/GVy3xA_MHlpQ

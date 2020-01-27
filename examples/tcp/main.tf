module "elb_logstash" {
  source = "terraform-flexibleengine-modules/elb/flexibleengine"
  version = "1.0.0"

  loadbalancer_name = "my-logstash-elb"

  subnet_id = "my-subnet-id"

  bind_eip = false

  vip_address = "192.168.13.148"

  listeners = [
              {
              name = "logstash"
              port = 5044
              protocol = "TCP"
              hasCert = false
              }
              ]

  pools = [   {
              name = "pool_logstash"
              protocol = "TCP"
              lb_method = "ROUND_ROBIN"
              listener_index = 0
              }
            ]

  backends = [
            {
              name = "backend1"
              port = 5044
              address_index = 0
              pool_index = 0
              subnet_id = "backend1-subnet-id"
            },
            {
              name = "backend2"
              port = 5044
              address_index = 1
              pool_index = 0
              subnet_id = "backend1-subnet-id"
            }
            ]

   backends_addresses = ["192.168.13.102","192.168.13.247"]

monitors =  [{
             name = "monitor1"
             pool_index = 0
             protocol = "TCP"
             delay = 20
             timeout = 10
             max_retries = 3
           }]

}

provider "aws" {
  region = "eu-west-1"  
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id             = "vpc-xxx"
  subnets            = ["subnet-xxx", "subnet-xxx"]
  security_groups    = ["sg-xxx"]



  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = {
        my_target = {
          target_id = "i-xxx"
          port = 80
        }
    }}
  ]

  https_listeners = [
    {
      port                 = 443
      protocol             = "HTTPS"
      certificate_arn      = "arn:aws:acm:eu-west-1:xxx:certificate/xxx-xxx-xx-xxx-xxx"
      action_type          = "authenticate-oidc"
      target_group_index   = 0
      authenticate_oidc = {
          authorization_endpoint = "https://dev-xxx.okta.com/oauth2/default/v1/authorize"
          client_id              = "xxxx"
          client_secret          = "xxxx-xxxx"
          issuer                 = "https://dev-xxx.okta.com/oauth2/default"
          token_endpoint         = "https://dev-xxx.okta.com/oauth2/default/v1/token"
          user_info_endpoint     = "https://dev-xxx.okta.com/oauth2/default/v1/userinfo"
          session_cookie_name    = "AWSELBAuthSessionCookie"
          session_timeout        = "300"
          scope                  = "openid profile"
          on_unauthenticated_request = "authenticate"

      }
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = "Test"
  }
}




output "aws_vpc_id" {
  value = "${aws_vpc.hmrs_np_vpc.id}"
}

output "aws_subnet_pub1a_id" {
  value = "${aws_subnet.hmrs_np_pub_subnet1a.id}"
}

output "aws_subnet_pub1b_id" {
  value = "${aws_subnet.hmrs_np_pub_subnet1b.id}"
}

output "aws_subnet_pvt1a_id" {
  value = "${aws_subnet.hmrs_np_pvt_subnet1a.id}"
}

output "aws_subnet_pvt1b_id" {
  value = "${aws_subnet.hmrs_np_pvt_subnet1b.id}"
}

output "private_rt_1_id" {
  value = "${aws_route_table.hmrs_np_pvt_rt.id}"
}


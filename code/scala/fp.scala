object fp {
    def main(args: Array[String]): Unit = {
        var employees = List("neal", "sSalkjdlkjalksdjkflasf", "asdas", "s", "asdasdasdasd")

        var result = employees.filter(_.length() > 1)
        .map(_.capitalize)
        .reduce(_ + "," + _)
        println(result)
    }                           
}                               

/**
 * slides2png4win is a Groovy script that plays a dzslides presentation using
 * WebDriver, captures each slide to a PNG and generates a shell script to
 * collate the PNGs together into a PDF using convert (from ImageMagick).
 *
 * The URL of the presentation is passed as the sole argument to the script.
 * If the presentation is local, specify the absolute path prefixed with the
 * file:// protocol.
 *
 * Make sure to set your screen resolution to the aspect ratio of the slides.
 *
 * slides2png4win relies on IMAGE_MAGICK_HOME environment variable pointing to
 * the directory where ImageMagick was unpacked.
 *
 * @author Dan Allen, Samuel Santos
 * @license ASLv2
 * @see https://gist.github.com/2998576
 */

@Grapes([
    @Grab("org.codehaus.geb:geb-core:0.7.2"),
    @Grab("org.seleniumhq.selenium:selenium-firefox-driver:2.30.0"),
    @Grab("org.seleniumhq.selenium:selenium-support:2.30.0")
])
import geb.Browser

if (args.length == 0) {
    println "Please specify the URL of the presentation"
    return
}

def url = args[0]

def reportsDir = "/tmp/geb-reports"
if (args.length > 1) {
    reportsDir = args[1]
}

Browser.drive {
    config.reportsDir = new File(reportsDir)
    cleanReportGroupDir()
    go url

    def idx = 1
    def body = $('body')
    body << 'f'
    sleep 500
    def script = null
    def selected = null
    while (selected == null || !selected.lastElement().equals($('[aria-selected=true]').lastElement())) {
        selected = $('[aria-selected=true]').last()
        report "slide_" + idx
        if (script == null) {
            script = new File(getReportGroupDir(), "to_pdf.bat")
            script.append("rem Convert PNGs files into a PDF\n\n")
            script.append("call cd $reportsDir\n")
            script.append("call \"%IMAGE_MAGICK_HOME%/convert\"")
        }
        script.append(" slide_" + idx + ".png")
        body << 'j'
        idx++
        sleep 500
    }
    script.append(" presentation.pdf")
    script.executable = true

    def out = new StringBuilder()
    def err = new StringBuilder()
    def proc = [script.absolutePath].execute()
    proc.consumeProcessOutput(out, err)
    proc.waitForOrKill(1000)
    println "out:\n$out"
    println "err:\n$err"
}.quit()

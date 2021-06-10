package imagereco

import (
	"bytes"
	"fmt"
	"image/color"
	"log"
	"sort"
	"strconv"
	"time"

	"github.com/hackranger/farm-monitor/domain"
	"github.com/machinebox/sdk-go/tagbox"
	"gocv.io/x/gocv"
)

var (
	blue            = color.RGBA{0, 0, 255, 0}
	tbox            = tagbox.New("http://localhost:9111")
	traingcount     = 10
	recentImage     []byte
	recentImageTags []domain.ImageTag
)

func InitImageRecognition() {
	recentImage = make([]byte, 0)
	recentImageTags = make([]domain.ImageTag, 0)
}

func GetRecentImage() []byte {
	return recentImage
}

func setRecentImage(img gocv.Mat) {
	data, err := gocv.IMEncode(".jpg", img)
	if err != nil {
		log.Printf("Unable to endcode the data")
	}
	recentImage = make([]byte, len(data))
	copy(recentImage, data)
}

func GetRecentImageTags() []domain.ImageTag {
	sort.Slice(recentImageTags, func(i, j int) bool {
		return recentImageTags[i].Confidance < recentImageTags[j].Confidance
	})
	return recentImageTags
}

func setRecentImageTags(tags []domain.ImageTag) {
	recentImageTags = make([]domain.ImageTag, len(tags))
	copy(recentImageTags, tags)
}

func trainTagBox() {
	for i := 1; i < traingcount; i++ {
		fmt.Println("Training image files")
		animal := gocv.IMRead(fmt.Sprintf("farmanimals/p%d.jpeg", i), gocv.IMReadAnyColor)

		if !animal.Empty() {
			buf, err := gocv.IMEncode(".jpg", animal)
			if err != nil {
				fmt.Printf("Unable to encode the image %e", err)
			}
			err = tbox.Teach(bytes.NewBuffer(buf), strconv.Itoa(i), "pig")
			if err != nil {
				fmt.Printf("Unable to teach image %e", err)
			}
		}
	}
}

func StartImageRecognitionAndTagging() {
	// Train with Know images
	// trainTagBox()

	// Access the camera
	webcam, err := gocv.VideoCaptureDevice(0)
	if err != nil {
		fmt.Println("Unable to init webcam, make sure came is attached")
		return
	}
	defer webcam.Close()

	img := gocv.NewMat()
	defer img.Close()

	// Read camera feed
	for {
		webcam.Read(&img)
		tags := checkAnimal(img)
		setRecentImage(img)
		setRecentImageTags(tags)
		time.Sleep(time.Second * 1)
	}
}

func checkAnimal(animal gocv.Mat) []domain.ImageTag {
	var tags []domain.ImageTag
	tags = make([]domain.ImageTag, 0)
	buf, err := gocv.IMEncode(".jpg", animal)
	if err != nil {
		fmt.Printf("Unable to encode the image %e", err)
	}
	res, err := tbox.Check(bytes.NewBuffer(buf))
	if err != nil {
		fmt.Printf("Unable to check image %e", err)
	}

	// These are the standard tags from generic model
	for _, p := range res.Tags {
		tag := domain.ImageTag{
			Tag:        p.Tag,
			Confidance: p.Confidence,
		}
		tags = append(tags, tag)
	}

	// These are the tags generated from trainined data
	for _, p := range res.CustomTags {
		tag := domain.ImageTag{
			Tag:        p.Tag,
			Confidance: p.Confidence,
		}
		tags = append(tags, tag)
	}

	return tags
}

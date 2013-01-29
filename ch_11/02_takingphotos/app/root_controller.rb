class RootController < UIViewController
  def viewDidLoad
    super
    view.backgroundColor = UIColor.lightGrayColor
    url='http://guarded-reef-8330.herokuapp.com/' 
    url = "http://localhost:3000"

    @client = AFMotion::Client.build(url) do
      header "Accept", "application/json"; 
      operation :json
    end

    @label = UILabel.new
    @label.text = 'Camera'
    @label.frame = [[0,50],[UIScreen.mainScreen.bounds.size.width,50]]
    view.addSubview(@label)

    @camera_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @camera_button.frame  = [[50, 20], [200, 50]]
    @camera_button.setTitle("Click from camera", forState:UIControlStateNormal)
    @camera_button.addTarget(self, action: :start_gallery, forControlEvents:UIControlEventTouchUpInside)

    @upload = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @upload.frame  = [[50, 120], [200, 50]]
    @upload.setTitle("Click from camera", forState:UIControlStateNormal)
    @upload.addTarget(self, action: :upload_image, forControlEvents:UIControlEventTouchUpInside)

    if camera_available? && takes_photos?
      @label.text = "Camera Good to Move on"
      p @label.text

      @image_picker = UIImagePickerController.alloc.init
      @image_picker.sourceType = UIImagePickerControllerSourceTypeCamera
      @image_picker.delegate = self
    else
      @label.text = "Camera not Available - Probably run in a simulator"
      p @label.text
    end

    view.addSubview(@camera_button)
    view.addSubview(@upload)
    view.addSubview(@image)
  end
  
  def start_gallery
    self.navigationController.presentModalViewController(@image_picker, animated:true)
  end

  #Tells the delegate that the user picked a still image or movie.
  def imagePickerController(picker, didFinishPickingImage:image, editingInfo:info)
    self.dismissModalViewControllerAnimated(true)
    @image_view.removeFromSuperview if @image_view
    @image_view = UIImageView.alloc.initWithImage(image)
    @image_view.frame = [[50, 200], [200, 180]]
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    upload_image(image)
    view.addSubview(@image_view)
  end

  def imagePickerControllerDidCancel(picker)
    @label.text = "Picker was cancelled"
    p @label.text
    picker.dismissModalViewControllerAnimated(true)
  end

  def upload_image#(image)
    image = UIImage.imageNamed('yay.jpg')
    data = UIImageJPEGRepresentation(image,1.0)
    @client.multipart.post("receipts") do |result, form_data, progress|
      if form_data
        form_data.appendPartWithFileData(data, name: "receipt", fileName:"yay.jpg", mimeType: "image/jpeg")
      elsif progress
        p progress
=begin
      elsif result.success?
        p 'success'
      elsif result.failure?
        'failed'
=end
      else
        'wtf'
      end
    end
  end

  def camera_available?
    UIImagePickerController.isSourceTypeAvailable UIImagePickerControllerSourceTypeCamera 
  end

  def cameraSupportsMedia paramMediaType, paramSourceType
    availableMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(paramSourceType)
    availableMediaTypes.include? paramMediaType
  end

  def shoots_videos?
    cameraSupportsMedia KUTTypeMovie, UIImagePickerControllerSourceTypeCamera
  end

  def takes_photos?
    cameraSupportsMedia KUTTypeImage, UIImagePickerControllerSourceTypeCamera
  end

  def has_front_camera?
    UIImagePickerController.isCameraDeviceAvailable UIImagePickerControllerCameraDeviceFront 
  end

  def has_rear_camera?
    UIImagePickerController.isCameraDeviceAvailable UIImagePickerControllerCameraDeviceRear 
  end

  def front_camera_flash?
    UIImagePickerController.isFlashAvailableForCameraDevice UIImagePickerControllerCameraDeviceFront 
  end

  def rear_camera_flash?
    UIImagePickerController.isFlashAvailableForCameraDevice UIImagePickerControllerCameraDeviceRear 
  end
end

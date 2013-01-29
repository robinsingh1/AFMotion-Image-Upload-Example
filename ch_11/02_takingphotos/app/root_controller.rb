class RootController < UIViewController
  def viewDidLoad
    super
    view.backgroundColor = UIColor.lightGrayColor
   
    @label = UILabel.new
    @label.text = 'Camera'
    @label.frame = [[0,50],[UIScreen.mainScreen.bounds.size.width,50]]
    view.addSubview(@label)

    @camera_button = UIButton.buttonWithType(UIButtonTypeRoundedRect)
    @camera_button.frame  = [[50, 20], [200, 50]]
    @camera_button.setTitle("Click from camera", forState:UIControlStateNormal)
    @camera_button.addTarget(self, action: :start_gallery, forControlEvents:UIControlEventTouchUpInside)

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
  end
  
  def start_gallery
    self.navigationController.presentModalViewController(@image_picker, animated:true)
  end

  # UIImagePickerController Delegate Methods
=begin
  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    p "Picker returned successfully"

    if mediaType.isEqualToString(KUTTypeMovie)
    elsif mediaType.isEqualToString(KUTTypeImage)
      
      @label.text = "Image = #{the_image}"
      p "Image Metadata = #{metadata}"
      p @label.text 
    end

    picker.dismissModalViewControllerAnimated(true)
  end
=end

  #Tells the delegate that the user picked a still image or movie.
  def imagePickerController(picker, didFinishPickingImage:image, editingInfo:info)
    self.dismissModalViewControllerAnimated(true)
    @image_view.removeFromSuperview if @image_view
    @image_view = UIImageView.alloc.initWithImage(image)
    @image_view.frame = [[50, 200], [200, 180]]
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    view.addSubview(@image_view)
  end

  def imagePickerControllerDidCancel(picker)
    @label.text = "Picker was cancelled"
    p @label.text
    picker.dismissModalViewControllerAnimated(true)
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

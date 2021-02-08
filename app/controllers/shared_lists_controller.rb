class SharedListsController < ApplicationController
  before_action :find_shared_list, only: %i[show add_contacts send_to_contacts]
  before_action :find_document, only: :create_and_attach_document
  before_action :find_folder, only: :create_and_attach_folder
  before_action :new_shared_list, only: %i[create_and_attach_document create_and_attach_folder]

  def index
    @shared_lists = policy_scope(SharedList)
  end

  def show
  end

  def create_and_attach_document
    @shared_document = @shared_list.shared_documents.new(document: @document)
    if @shared_list.save
      redirect_to document_path(@document), flash: { validation_message: true, message: "Votre liste de partage a bien été créée et votre document a bien été ajouté." }
    else
      flash.now[:errors_attach_document] = true
      render 'documents/show'
    end
  end

  def create_and_attach_folder
    @folders = policy_scope(Folder)
    @shared_folder = @shared_list.shared_folders.new(folder: @folder)
    if @shared_list.save
      redirect_to folder_path(@folder), flash: { validation_message: true, message: "Votre liste de partage a bien été créée et votre dossier a bien été ajouté." }
    else
      flash.now[:errors_attach_folder] = true
      render 'folders/index'
    end
  end

  def add_contacts
    @shared_list.contacts.destroy_all if @shared_list.contacts.present?
    emails = contacts_params[:contacts][:email].split(/\s{1,}*[,;\/]\s{1,}*|\s{1,}/).uniq
    # \s{1,}*[,;\/]\s{1,}* (, ; ou / précédé et optionnellement précédé par un ou plusieurs espaces OU un ou plusieurs espaces
    @errors = Array.new
    emails.each do |email|
      contact = @shared_list.contacts.new(email: email)
      if contact.save
      else
        @errors << "#{contact.email}: #{contact.errors.full_messages.join(', ')}"
      end
    end
    if @errors.empty?
      if @shared_list.contacts.present?
        @shared_list.add_contacts!
        redirect_to shared_list_path(@shared_list), flash: { validation_message: true, message: "Votre liste de partage a bien été envoyée." }
      else
        flash.now.alert = "Votre liste de partage ne contient pas de destinataire."
        render :show
      end
    else
      flash.now.alert = @errors.join("<br>").html_safe
      render :show
    end
  end

  private

  def find_shared_list
    @shared_list = SharedList.find(params[:id])
    authorize @shared_list
  end

  def new_shared_list
    @shared_list = current_user.shared_lists.new(shared_list_params)
    authorize @shared_list
  end

  def find_folder
    @folder = Folder.find(params[:folder_id])
  end

  def find_document
    @document = Document.find(params[:document_id]).decorate
  end

  def contacts_params
    params.require(:shared_list).permit(contacts: [:email])
  end

  def shared_list_params
    params.require(:shared_list).permit(:title)
  end
end

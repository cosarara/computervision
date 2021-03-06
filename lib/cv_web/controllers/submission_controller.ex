defmodule CvWeb.SubmissionController do
  use CvWeb, :controller

  alias Cv.Submissions
  alias Cv.Submissions.Submission

  def index(conn, _params) do
    submissions = Submissions.list_submissions()
    render(conn, "index.html", submissions: submissions)
  end

  def new(conn, _params) do
    changeset = Submissions.change_submission(%Submission{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"submission" => submission_params}) do
    case Submissions.create_submission(submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission created successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def img(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    IO.inspect submission.mime
    conn = put_resp_content_type(conn, submission.mime)
    resp(conn, 200, submission.image)
  end

  def show(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    render(conn, "show.html", submission: submission)
  end

  def edit(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    changeset = Submissions.change_submission(submission)
    render(conn, "edit.html", submission: submission, changeset: changeset)
  end

  def update(conn, %{"id" => id, "submission" => submission_params}) do
    submission = Submissions.get_submission!(id)

    case Submissions.update_submission(submission, submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission updated successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", submission: submission, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    {:ok, _submission} = Submissions.delete_submission(submission)

    conn
    |> put_flash(:info, "Submission deleted successfully.")
    |> redirect(to: Routes.submission_path(conn, :index))
  end
end

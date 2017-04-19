defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  alias Rumbl.Video

  @valid_attrs %{url: "http://www.youtu.be", title: "Example vid", description: "Test video"}
  @invalid_attrs %{title: " This is not valid!"}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(%{username: username})
      conn = assign build_conn(), :current_user, user
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  defp video_count(query), do: Repo.one from v in query, select: count(v.id)

  test "requires authentication on all pages" do
    Enum.each([
        get(build_conn(), video_path(build_conn(), :index)),
        get(build_conn(), video_path(build_conn(), :new)),
        get(build_conn(), video_path(build_conn(), :show, "123")),
        get(build_conn(), video_path(build_conn(), :edit, "123")),
        get(build_conn(), video_path(build_conn(), :update, "123", %{})),
        get(build_conn(), video_path(build_conn(), :create, %{})),
        get(build_conn(), video_path(build_conn(), :delete, "123")),
      ], fn conn ->
          assert html_response(conn, 302)
          assert conn.halted
      end)
  end

  @tag login_as: "Alex63"
  test "list all user's videos on index", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "lolcats")
    other_video = insert_video(
      insert_user(%{username: "other test"}), title: "Longer vid")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  @tag login_as: "Alex63"
  test "creates user video and redirects", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path conn, :index
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "Alex63"
  test "does not creates user video and renders error when invalid", %{conn: conn} do
    count_before = video_count Video
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert video_count(Video) == count_before
  end

  @tag login_as: "Alex63"
  test "authorises actions against acces by other users", %{conn: conn, user: owner} do
    video = insert_video(owner, @valid_attrs)

    non_owner = insert_user(%{username: "sneaky"})
    conn = assign conn, :current_user, non_owner

    assert_error_sent :not_found, fn ->
      get conn, video_path(conn, :show, video)
    end

    assert_error_sent :not_found, fn ->
      get conn, video_path(conn, :edit, video)
    end

    assert_error_sent :not_found, fn ->
      put conn, video_path(conn, :update, video, video: @valid_attrs)
    end

    assert_error_sent :not_found, fn ->
      delete conn, video_path(conn, :delete, video)
    end
  end
end
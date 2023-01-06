package test

import (
	"encoding/json"
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"
)

// testing the Terraform code used ot deploy the lambda function.
func TestTerraformLambda(t *testing.T) {
	t.Parallel()

	// Giving the lambda function a unique ID for a name so it doesn't conflict with other functions in the  AWS account
	functionName := fmt.Sprintf("terratest-aws-lambda-%s", random.UniqueId())

	// Picking a random AWS region to test in. This helps ensure your code works in all regions.
	awsRegion := aws.GetRandomStableRegion(t, nil, nil)

	// Construct the terraform options with default retryable errors to handle the most common retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../image-downloader-function",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"function_name": functionName,
			"region":        awsRegion,
		},
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	type Record struct {
		Body string `json:"body"`
	}
	type Message struct {
		Records []Record `json:"Records"`
	}

	x := &Message{
		Records: []Record{
			{
				Body: `{"animal": "squirrel", "number": "1"}`,
			},
		},
	}

	// Invoke the function, so we can test its output
	response := aws.InvokeFunction(t, awsRegion, functionName, x)
	assert.NotEmpty(t, response)

	var responseData map[string]interface{}
	json.Unmarshal(response, &responseData)
	assert.Equal(t, float64(200), responseData["statusCode"]) //confirming we receieve the status code of 200 which means the functions has no errors
}
